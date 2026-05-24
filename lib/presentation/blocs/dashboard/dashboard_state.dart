abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  DashboardLoaded(this.data);
}

class DashboardData {
  final double totalExpenseThisMonth;
  final double totalFuelCostThisMonth;
  final double totalServiceCostThisMonth;
  final double avgConsumption;
  final int fuelCountThisMonth;
  final int serviceCountThisMonth;
  final List<ActivityItem> recentActivities;
  final List<ReminderItem> reminders;

  DashboardData({
    required this.totalExpenseThisMonth,
    required this.totalFuelCostThisMonth,
    required this.totalServiceCostThisMonth,
    required this.avgConsumption,
    required this.fuelCountThisMonth,
    required this.serviceCountThisMonth,
    required this.recentActivities,
    required this.reminders,
  });
}

class ActivityItem {
  final String type; // 'fuel' or 'service'
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;

  ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
  });
}

class ReminderItem {
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final int daysUntil;
  final double? nextOdometer;

  ReminderItem({
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.daysUntil,
    this.nextOdometer,
  });
}
