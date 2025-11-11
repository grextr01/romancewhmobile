import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/UX/Api.dart';
import '../../Controllers/barcode_controller.dart';

class BarcodeCubit extends Cubit<BarcodeController> {
  BarcodeCubit(super.initialState);
  API api = API();
  Future<bool> scannBarcode(String barcode) async {
    //barcode = '5281076505452';
    emit(state.copyWith(loading: true, scannedBarcode: barcode));
    var response = await api.getApiToMap(
        api.apiBaseUrl,
        '/Warehouse/romance/barcode?legalEntityId=${state.leCode}&barcode=$barcode',
        'get');
    if (response['statusCode'] == 200) {
      if (response['data'] != null && response['data'].isNotEmpty) {
        emit(state.copyWith(
            scannedBarcode: barcode,
            items: [...response['data']],
            error: false,
            loading: false));
        return true;
      } else {
        emit(state.copyWith(
            error: true,
            errorMessage: 'No data found',
            loading: false,
            items: []));
        return false;
      }
    } else {
      emit(state.copyWith(
          error: true,
          errorMessage: response['message'],
          loading: false,
          items: []));
      return false;
    }
  }

  void setLeCode(String leCode) {
    emit(state.copyWith(leCode: leCode));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(loading: loading));
  }
}
