import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaibo/routes/app_navigator.dart';
import 'package:kaibo/utils/app_utils.dart';
import 'package:kaibo/utils/logger.dart';
import 'package:kaibo/widgets/app_widget.dart';
import 'package:kaibo/views/loading_view.dart';
import 'package:kaibo/apis.dart';
import 'package:kaibo/resources/lang.dart';
import 'package:kaibo/pages/index/index_logic.dart';

class BalanceTransferLogic extends GetxController {
  final indexLogic = Get.find<IndexLogic>();
  final transferAccCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final remainingBalance = ''.obs; // 余额宝
  final transferAccName = ''.obs;

  void transferHistory() => AppNavigator.startBalanceTransferHistory();

  @override
  void onInit() {
    remainingBalance.value = indexLogic.profile.value.canWithdrawBalance ?? '--';
    super.onInit();
  }

  Future<void> search() async {
    if (transferAccCtrl.text.isEmpty) {
      AppWidget.showToast(Globe.plsEnterTransferToAcc);
      return;
    }
    if (!AppUtils.isChinaMobile(transferAccCtrl.text)) {
      AppWidget.showToast(Globe.plsEnterValidTransferAcc);
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        transferAccName.value =
            await Apis.checkName(phone: transferAccCtrl.text);
      } catch (e, s) {
        Logger.print('transfer e: $e $s');
      }
    });
  }

  Future<void> transfer() async {
    if (transferAccCtrl.text.isEmpty) {
      AppWidget.showToast(Globe.plsEnterTransferToAcc);
      return;
    }
    if (amountCtrl.text.isEmpty) {
      AppWidget.showToast(Globe.plsEnterDepositAmt);
      return;
    }
    final points = double.parse(remainingBalance.value);
    final transferAmt = double.parse(amountCtrl.text);
    if (transferAmt > points) {
      AppWidget.showToast(Globe.notEnoughBalance);
      return;
    }
    if (pwdCtrl.text.isEmpty) {
      AppWidget.showToast(Globe.plsEnterWithdrawalPwd);
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      try {
        final suc = await Apis.transferBalance(
          phone: transferAccCtrl.text,
          amount: amountCtrl.text,
          pwd: pwdCtrl.text,
        );
        if (suc) {
          transferAccCtrl.text = "";
          transferAccName.value = "";
          amountCtrl.text = "";
          pwdCtrl.text = "";
          indexLogic.getProfile();
          Get.back();
          Get.back();
        }
      } catch (e, s) {
        Logger.print('transfer e: $e $s');
      }
    });
  }
}
