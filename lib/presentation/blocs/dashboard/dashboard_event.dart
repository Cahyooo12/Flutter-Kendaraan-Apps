abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {
  final int vehicleId;
  LoadDashboard(this.vehicleId);
}
