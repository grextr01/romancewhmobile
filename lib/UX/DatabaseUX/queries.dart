String get createPortfolioTable {
  return 'CREATE TABLE "Portfolio" ('
      '"barcode" TEXT NOT NULL,'
      '"ItemCode" TEXT NOT NULL,'
      '"Description" TEXT NOT NULL);';
}

String get createCycleCountHeader {
  return 'CREATE TABLE "CycleCountHeader"('
      '"Id" INTEGER NOT NULL UNIQUE,'
      '"Portfolio" TEXT,'
      '"Text" TEXT,'
      '"timestamp" TEXT,'
      '"userId" INT,'
      'PRIMARY KEY("Id" AUTOINCREMENT));';
}

String get createCycleCountDetails {
  return 'CREATE TABLE "CycleCountDetails"('
      '"detailId" INTEGER NOT NULL UNIQUE,'
      '"HeaderId" INTEGER NOT NULL,'
      '"barcode" TEXT NOT NULL,'
      '"ItemCode" TEXT NOT NULL,'
      '"Description" TEXT NOT NULL,'
      '"quantity" INTEGER NOT NULL,'
      '"notes" TEXT,'
      '"picture" TEXT,'
      '"timestamp" TEXT,'
      '"isAutomatic" BOOLEAN,'
      'PRIMARY KEY("detailId" AUTOINCREMENT),'
      'FOREIGN KEY("HeaderId") REFERENCES "CycleCountHeader"("Id")'
      ');';
}
