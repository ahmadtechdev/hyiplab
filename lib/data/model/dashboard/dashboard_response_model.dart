

import 'package:hyip_lab/data/model/user/user.dart';

import '../auth/sign_up_model/registration_response_model.dart';

class DashboardResponseModel {
  DashboardResponseModel({
      String? remark, 
      String? status, 
      Message? message, 
      MainData? data,}){
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
}

  DashboardResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'];
    _message = json['message'] != null ? Message.fromJson(json['message']) : null;
    _data = json['data'] != null ? MainData.fromJson(json['data']) : null;
  }
  String? _remark;
  String? _status;
  Message? _message;
  MainData? _data;

  String? get remark => _remark;
  String? get status => _status;
  Message? get message => _message;
  MainData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = _remark;
    map['status'] = _status;
    if (_message != null) {
      map['message'] = _message?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

class MainData {
  MainData({
      User? user, 
      String? totalInvest, 
      String? totalDeposit, 
      String? totalWithdrawal, 
      String? referralEarnings, 
      String? pendingDeposit, 
      String? pendingWithdraw
    }){
    _user = user;
    _totalInvest = totalInvest;
    _totalDeposit = totalDeposit;
    _totalWithdrawal = totalWithdrawal;
    _referralEarnings = referralEarnings;
    _pendingDeposit = pendingDeposit;
    _pendingWithdraw = pendingWithdraw;
}

  MainData.fromJson(dynamic json) {
    _user             =  json['user']              !=null? User.fromJson(json['user']) : null;
    _totalInvest      =  json['total_invest']      !=null? json['total_invest'].toString():'0';
    _totalDeposit     =  json['total_deposit']     !=null? json['total_deposit'].toString():'0';
    _totalWithdrawal  =  json['total_withdrawal']  !=null? json['total_withdrawal'] .toString():'0';
    _referralEarnings =  json['referral_earnings'] !=null? json['referral_earnings'] .toString():'0';
    _pendingDeposit   =  json['pending_deposit']   !=null? json['pending_deposit'].toString():'0';
    _pendingWithdraw  =  json['pending_withdraw']  !=null? json['pending_withdraw'] .toString():'0';
  }

  User? _user;
  String? _totalInvest;
  String? _totalDeposit;
  String? _totalWithdrawal;
  String? _referralEarnings;
  String? _pendingDeposit;
  String? _pendingWithdraw;

  User?   get user => _user;
  String? get totalInvest => _totalInvest;
  String? get totalDeposit => _totalDeposit;
  String? get totalWithdrawal => _totalWithdrawal;
  String? get referralEarnings => _referralEarnings;
  String? get pendingDeposit => _pendingDeposit;
  String? get pendingWithdraw => _pendingWithdraw;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['total_invest']       = _totalInvest;
    map['total_deposit']      = _totalDeposit;
    map['total_withdrawal']   = _totalWithdrawal;
    map['referral_earnings']  = _referralEarnings;
    map['pending_deposit']    = _pendingDeposit;
    map['pending_withdraw']   = _pendingWithdraw;

    return map;
  }

}

