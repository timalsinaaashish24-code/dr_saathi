import 'dart:math';
import '../models/user_analytics.dart';

class AnalyticsService {
  // Mock data service - replace with actual API/database calls
  
  Future<UserAnalytics> getUserAnalytics(String period) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate mock data based on period
    final random = Random();
    final days = _getDaysFromPeriod(period);
    
    final totalUsers = 15420 + random.nextInt(1000);
    final activeUsers = (totalUsers * 0.65).toInt();
    final todayActive = (activeUsers * 0.15).toInt();
    
    return UserAnalytics(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      todayActiveUsers: todayActive,
      weeklyActiveUsers: (activeUsers * 0.8).toInt(),
      monthlyActiveUsers: (activeUsers * 0.95).toInt(),
      inactiveUsers: totalUsers - activeUsers,
      totalDownloads: 45680 + random.nextInt(5000),
      iosDownloads: 20340 + random.nextInt(2000),
      androidDownloads: 25340 + random.nextInt(3000),
      patientUsers: (totalUsers * 0.75).toInt(),
      doctorUsers: (totalUsers * 0.20).toInt(),
      otherUsers: (totalUsers * 0.05).toInt(),
      userGrowth: 12.5 + (random.nextDouble() * 10),
      downloadGrowth: 8.3 + (random.nextDouble() * 10),
      dailyGrowth: _generateDailyGrowth(days),
      dailyActiveUsers: _generateDailyActive(days),
      dailyDownloads: _generateDailyDownloads(days),
    );
  }
  
  int _getDaysFromPeriod(String period) {
    switch (period) {
      case '7days':
        return 7;
      case '30days':
        return 30;
      case '90days':
        return 90;
      case '1year':
        return 365;
      default:
        return 7;
    }
  }
  
  List<DailyData> _generateDailyGrowth(int days) {
    final random = Random();
    final List<DailyData> data = [];
    int baseUsers = 10000;
    
    final displayDays = days > 30 ? 30 : days; // Limit chart data points
    final step = days > 30 ? (days / 30).floor() : 1;
    
    for (int i = 0; i < displayDays; i++) {
      baseUsers += random.nextInt(200) - 50; // Random growth/decline
      data.add(DailyData(
        date: _formatDate(days - (i * step)),
        users: baseUsers,
      ));
    }
    
    return data.reversed.toList();
  }
  
  List<DailyData> _generateDailyActive(int days) {
    final random = Random();
    final List<DailyData> data = [];
    int baseActive = 6000;
    
    final displayDays = days > 30 ? 30 : days;
    final step = days > 30 ? (days / 30).floor() : 1;
    
    for (int i = 0; i < displayDays; i++) {
      baseActive += random.nextInt(150) - 40;
      data.add(DailyData(
        date: _formatDate(days - (i * step)),
        users: baseActive,
      ));
    }
    
    return data.reversed.toList();
  }
  
  List<DownloadData> _generateDailyDownloads(int days) {
    final random = Random();
    final List<DownloadData> data = [];
    int baseDownloads = 40000;
    
    final displayDays = days > 30 ? 30 : days;
    final step = days > 30 ? (days / 30).floor() : 1;
    
    for (int i = 0; i < displayDays; i++) {
      baseDownloads += random.nextInt(300) - 50;
      data.add(DownloadData(
        date: _formatDate(days - (i * step)),
        downloads: baseDownloads,
      ));
    }
    
    return data.reversed.toList();
  }
  
  String _formatDate(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return '${date.month}/${date.day}';
  }
}
