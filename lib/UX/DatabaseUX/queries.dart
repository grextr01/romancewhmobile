String get createPortfolioTable {
  return '''CREATE TABLE portfolio(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT NOT NULL,
        itemCode TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT
        ,UNIQUE ("barcode", "ItemCode"));''';
}

String get createCycleCountHeader {
  return '''CREATE TABLE cycle_count_header(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        portfolio TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        userId TEXT NOT NULL,
        totalItems INTEGER DEFAULT 0,
        scannedItems INTEGER DEFAULT 0
      )''';
}

String get createCycleCountDetails {
  return '''CREATE TABLE cycle_count_details(
        detailId INTEGER PRIMARY KEY AUTOINCREMENT,
        headerId INTEGER NOT NULL,
        barcode TEXT NOT NULL,
        itemCode TEXT NOT NULL,
        description TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        picture TEXT,
        timestamp TEXT NOT NULL,
        isAutomatic INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(headerId) REFERENCES cycle_count_header(id)
      )
''';
}
