import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'remote_config_service.dart';

class QueryLimitService {
  static Future<int> getRemainingQueries() async {
    final user = SupabaseService.currentUser;
    if (user == null) return 0;

    final today = DateTime.now().toUtc();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final result = await SupabaseService.client
          .from('user_queries_limit')
          .select('remaining_queries')
          .eq('user_id', user.id)
          .eq('query_date', dateStr)
          .maybeSingle();

      if (result == null) {
        final defaultLimit = await RemoteConfigService.getModalDailyLimit();
        await _initializeDailyLimit(user.id, dateStr, defaultLimit);
        return defaultLimit;
      }

      return result['remaining_queries'] as int;
    } catch (e) {
      final defaultLimit = await RemoteConfigService.getModalDailyLimit();
      return defaultLimit;
    }
  }

  static Future<bool> canMakeQuery() async {
    final remaining = await getRemainingQueries();
    return remaining > 0;
  }

  static Future<void> decrementQuery() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    final today = DateTime.now().toUtc();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final result = await SupabaseService.client
          .from('user_queries_limit')
          .select('remaining_queries')
          .eq('user_id', user.id)
          .eq('query_date', dateStr)
          .maybeSingle();

      if (result == null) {
        final defaultLimit = await RemoteConfigService.getModalDailyLimit();
        await SupabaseService.client.from('user_queries_limit').insert({
          'user_id': user.id,
          'query_date': dateStr,
          'remaining_queries': defaultLimit - 1,
        });
      } else {
        final current = result['remaining_queries'] as int;
        if (current > 0) {
          await SupabaseService.client
              .from('user_queries_limit')
              .update({'remaining_queries': current - 1})
              .eq('user_id', user.id)
              .eq('query_date', dateStr);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> _initializeDailyLimit(String userId, String dateStr, int limit) async {
    try {
      await SupabaseService.client.from('user_queries_limit').insert({
        'user_id': userId,
        'query_date': dateStr,
        'remaining_queries': limit,
      });
    } catch (e) {
      // Silently fail
    }
  }
}
