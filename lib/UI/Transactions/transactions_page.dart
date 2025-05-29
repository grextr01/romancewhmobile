import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:romancewhs/Bloc/Trx_Details_bloc/trx_details_page_bloc.dart';
import 'package:romancewhs/Models/transaction_detail.dart';
import 'package:romancewhs/UX/Api.dart';
import 'package:romancewhs/main.dart';

import '../../UX/Theme.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.transactions});
  final List transactions;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController transactionTypeController =
      TextEditingController();
  List transactions = [];
  API api = API();

  @override
  void initState() {
    transactions = [...widget.transactions];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: secondaryColor,
          shadowColor: const Color.fromRGBO(206, 206, 206, 100),
          title: const Text(
            'Transactions',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: transactionTypeController,
              onChanged: (value) {
                transactions = widget.transactions.where((element) {
                  return element['CONS_BILLING_NUMBER']
                      .toString()
                      .toLowerCase()
                      .contains(value.toLowerCase());
                }).toList();
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Cons Billing Number..',
                contentPadding: const EdgeInsets.only(left: 12),
                suffix: IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () {
                    transactionTypeController.clear();
                    transactions = [...widget.transactions];
                    setState(() {});
                  },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      // List<TransactionDetail> transactionDetails =
                      //     await getTransactionDetails(
                      //         transactions[index]['TRX_HEADER_ID']);
                      mainNavigatorKey.currentState!.push(MaterialPageRoute(
                          builder: (_) => TrxDetailsBlocPage(
                                headerId: transactions[index]['TRX_HEADER_ID'],
                                trxHeader: transactions[index],
                                onSubmit: (headerId) {
                                  transactions.removeWhere((transaction) =>
                                      transaction['TRX_HEADER_ID'].toString() ==
                                      headerId);
                                  setState(() {});
                                },
                              )));
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 15, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(TextSpan(
                              text: 'Cons Billing Number: ',
                              style: const TextStyle(
                                  fontSize: 16.5, fontWeight: FontWeight.w700),
                              children: [
                                TextSpan(
                                    text: transactions[index]
                                            ['CONS_BILLING_NUMBER']
                                        .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ])),
                          Text.rich(TextSpan(
                              text: 'Customer: ',
                              style: const TextStyle(
                                  fontSize: 16.5, fontWeight: FontWeight.w700),
                              children: [
                                TextSpan(
                                    text: transactions[index]['CUSTOMER_NAME']
                                        .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ])),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }

  Future<List<TransactionDetail>> getTransactionDetails(int headerId) async {
    List<TransactionDetail> transactionDetails = [];
    var response = await api.getApiToMap(
        api.apiBaseUrl, '/Warehouse/romance/details/$headerId', 'get');
    if (response['statusCode'] == 200) {
      List data = response['data'];
      transactionDetails =
          data.map((item) => TransactionDetail.fromJson(item)).toList();
      // transactionDetails.add(TransactionDetail(
      //     lineId: '1',
      //     orgId: '158',
      //     orgCode: 'test',
      //     itemCode: '123456',
      //     description: 'Test Item',
      //     quantity: 5,
      //     freeQty: 0,
      //     barcode: '762220143053'));
    } else {}
    return transactionDetails;
  }
}
