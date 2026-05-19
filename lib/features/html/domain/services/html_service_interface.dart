import 'package:get/get.dart';
import 'package:apna_demand/util/html_type.dart';

abstract class HtmlServiceInterface{
  Future<Response> getHtmlText(HtmlType htmlType);
}
