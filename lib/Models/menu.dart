class Menu {
  int menuId;
  String description;
  String? route;
  String action;

  Menu({
    required this.menuId,
    required this.description,
    this.route,
    required this.action,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      menuId: json['MenuId'],
      description: json['Description'],
      route: json['Route'],
      action: json['Action'],
    );
  }
}