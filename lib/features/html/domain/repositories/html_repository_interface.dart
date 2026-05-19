import 'package:apna_demand/interfaces/repository_interface.dart';
import 'package:apna_demand/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}
