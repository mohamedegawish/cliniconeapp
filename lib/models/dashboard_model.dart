class DashboardModel {
  final DashboardClinic? clinic;
  final DashboardDoctor? doctor;
  final DashboardToday today;
  final DashboardTotals totals;
  final List<MonthlyChartPoint> monthlyChart;
  final int unreadNotifications;
  final List<Map<String, dynamic>> recentAppointments;

  const DashboardModel({
    this.clinic,
    this.doctor,
    required this.today,
    required this.totals,
    required this.monthlyChart,
    required this.unreadNotifications,
    required this.recentAppointments,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    clinic: json['clinic'] != null
        ? DashboardClinic.fromJson(json['clinic'] as Map<String, dynamic>)
        : null,
    doctor: json['doctor'] != null
        ? DashboardDoctor.fromJson(json['doctor'] as Map<String, dynamic>)
        : null,
    today:  DashboardToday.fromJson((json['today'] as Map<String, dynamic>?) ?? {}),
    totals: DashboardTotals.fromJson((json['totals'] as Map<String, dynamic>?) ?? {}),
    monthlyChart: (json['monthly_chart'] as List? ?? [])
        .map((p) => MonthlyChartPoint.fromJson(p as Map<String, dynamic>))
        .toList(),
    unreadNotifications: json['unread_notifications'] as int? ?? 0,
    recentAppointments:  (json['recent_appointments'] as List? ?? [])
        .cast<Map<String, dynamic>>(),
  );
}

class DashboardClinic {
  final int id;
  final String name;
  final String? logo;
  final String? phone;
  final String? address;
  final String primaryColor;

  const DashboardClinic({required this.id, required this.name, this.logo, this.phone, this.address, required this.primaryColor});

  factory DashboardClinic.fromJson(Map<String, dynamic> j) => DashboardClinic(
    id:           j['id'] as int? ?? 0,
    name:         j['name'] as String? ?? '',
    logo:         j['logo'] as String?,
    phone:        j['phone'] as String?,
    address:      j['address'] as String?,
    primaryColor: j['primary_color'] as String? ?? '#1a56c8',
  );
}

class DashboardDoctor {
  final int id;
  final String name;
  final String? specialty;
  final double price;
  final double followupPrice;

  const DashboardDoctor({required this.id, required this.name, this.specialty, required this.price, required this.followupPrice});

  factory DashboardDoctor.fromJson(Map<String, dynamic> j) => DashboardDoctor(
    id:            j['id'] as int? ?? 0,
    name:          j['name'] as String? ?? '',
    specialty:     j['specialty'] as String?,
    price:         (j['price'] as num? ?? 0).toDouble(),
    followupPrice: (j['followup_price'] as num? ?? 0).toDouble(),
  );
}

class DashboardToday {
  final int total;
  final int completed;
  final int pending;
  final double revenue;

  const DashboardToday({required this.total, required this.completed, required this.pending, required this.revenue});

  factory DashboardToday.fromJson(Map<String, dynamic> j) => DashboardToday(
    total:     j['total'] as int? ?? 0,
    completed: j['completed'] as int? ?? 0,
    pending:   j['pending'] as int? ?? 0,
    revenue:   (j['revenue'] as num? ?? 0).toDouble(),
  );
}

class DashboardTotals {
  final int patients;
  final int appointments;
  final double revenue;
  final double revenueMonth;
  final double expenses;
  final double expensesMonth;
  final double netProfit;
  final double netProfitMonth;

  const DashboardTotals({
    required this.patients,
    required this.appointments,
    required this.revenue,
    required this.revenueMonth,
    required this.expenses,
    required this.expensesMonth,
    required this.netProfit,
    required this.netProfitMonth,
  });

  factory DashboardTotals.fromJson(Map<String, dynamic> j) => DashboardTotals(
    patients:       j['patients'] as int? ?? 0,
    appointments:   j['appointments'] as int? ?? 0,
    revenue:        (j['revenue'] as num? ?? 0).toDouble(),
    revenueMonth:   (j['revenue_month'] as num? ?? 0).toDouble(),
    expenses:       (j['expenses'] as num? ?? 0).toDouble(),
    expensesMonth:  (j['expenses_month'] as num? ?? 0).toDouble(),
    netProfit:      (j['net_profit'] as num? ?? 0).toDouble(),
    netProfitMonth: (j['net_profit_month'] as num? ?? 0).toDouble(),
  );
}

class MonthlyChartPoint {
  final String month;
  final String label;
  final int count;
  final double revenue;

  const MonthlyChartPoint({required this.month, required this.label, required this.count, required this.revenue});

  factory MonthlyChartPoint.fromJson(Map<String, dynamic> j) => MonthlyChartPoint(
    month:   j['month'] as String? ?? '',
    label:   j['label'] as String? ?? '',
    count:   j['count'] as int? ?? 0,
    revenue: (j['revenue'] as num? ?? 0).toDouble(),
  );
}
