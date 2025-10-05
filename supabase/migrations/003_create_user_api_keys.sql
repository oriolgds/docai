-- Tabla para claves API BYOK de usuarios
CREATE TABLE user_api_keys (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    provider TEXT NOT NULL DEFAULT 'openrouter',
    api_key TEXT NOT NULL, -- Encriptada con pgp_sym_encrypt
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, provider)
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_user_api_keys_user_id ON user_api_keys(user_id);
CREATE INDEX idx_user_api_keys_provider ON user_api_keys(provider);

-- RLS (Row Level Security) policies
ALTER TABLE user_api_keys ENABLE ROW LEVEL SECURITY;

-- Policy: los usuarios solo pueden ver sus propias claves API
CREATE POLICY "Users can view own api keys" ON user_api_keys
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own api keys" ON user_api_keys
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own api keys" ON user_api_keys
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own api keys" ON user_api_keys
    FOR DELETE USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at en user_api_keys
CREATE TRIGGER update_user_api_keys_updated_at
    BEFORE UPDATE ON user_api_keys
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Función para encriptar clave API
CREATE OR REPLACE FUNCTION encrypt_api_key(plain_key TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Usar una clave de encriptación fija (en producción usar variable de entorno)
    RETURN pgp_sym_encrypt(plain_key, 'docai_byok_encryption_key_2024');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para desencriptar clave API
CREATE OR REPLACE FUNCTION decrypt_api_key(encrypted_key TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Usar la misma clave de encriptación
    RETURN pgp_sym_decrypt(encrypted_key, 'docai_byok_encryption_key_2024');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;