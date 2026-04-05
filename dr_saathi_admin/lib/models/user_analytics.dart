class UserAnalytics {
  final int totalUsers;
  final int activeUsers;
  final int todayActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final int inactiveUsers;
  final int totalDownloads;
  final int iosDownloads;
  final int androidDownloads;
  final int patientUsers;
  final int doctorUsers;
  final int otherUsers;
  final double userGrowth;
  final double downloadGrowth;
  final List<DailyData> dailyGrowth;
  final List<DailyData> dailyActiveUsers;
  final List<DownloadData> dailyDownloads;

  UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.todayActiveUsers,
    required this.weeklyActiveUsers,
    required this.monthlyActiveUsers,
    required this.inactiveUsers,
    required this.totalDownloads,
    required this.iosDownloads,
    required this.androidDownloads,
    required this.patientUsers,
    required this.doctorUsers,
    required this.otherUsers,
    required this.userGrowth,
    required this.downloadGrowth,
    required this.dailyGrowth,
    required this.dailyActiveUsers,
    required this.dailyDownloads,
  });
}

class DailyData {
  final String date;
  final int users;

  DailyData({required this.date, required this.users});
}

class DownloadData {
  final String date;
  final int downloads;

  DownloadData({required this.date, required this.downloads});
}
