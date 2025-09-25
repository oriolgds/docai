-- Tabla para conversaciones de chat
CREATE TABLE chat_conversations (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla para mensajes de chat
CREATE TABLE chat_messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT REFERENCES chat_conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_chat_conversations_user_id ON chat_conversations(user_id);
CREATE INDEX idx_chat_conversations_updated_at ON chat_conversations(updated_at DESC);
CREATE INDEX idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);

-- RLS (Row Level Security) policies
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policy para chat_conversations: los usuarios solo pueden ver sus propias conversaciones
CREATE POLICY "Users can view own conversations" ON chat_conversations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations" ON chat_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations" ON chat_conversations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations" ON chat_conversations
    FOR DELETE USING (auth.uid() = user_id);

-- Policy para chat_messages: los usuarios solo pueden ver mensajes de sus conversaciones
CREATE POLICY "Users can view own messages" ON chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE chat_conversations.id = chat_messages.conversation_id 
            AND chat_conversations.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own messages" ON chat_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE chat_conversations.id = chat_messages.conversation_id 
            AND chat_conversations.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own messages" ON chat_messages
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE chat_conversations.id = chat_messages.conversation_id 
            AND chat_conversations.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own messages" ON chat_messages
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM chat_conversations 
            WHERE chat_conversations.id = chat_messages.conversation_id 
            AND chat_conversations.user_id = auth.uid()
        )
    );

-- Función para actualizar automáticamente updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at en chat_conversations
CREATE TRIGGER update_chat_conversations_updated_at 
    BEFORE UPDATE ON chat_conversations 
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();