class MenuItem {
  int menuId;
  String description;
  String? route;  // Can be null for actions that don't navigate
  String action;

  MenuItem({
    required this.menuId,
    required this.description,
    this.route,
    required this.action,
  });

  factory MenuItem.fromJson(Map json) {
    return MenuItem(
      menuId: json['MenuId'] as int,
      description: json['Description'] as String,
      route: json['Route'] as String?,
      action: json['Action'] as String,
    );
  }
}