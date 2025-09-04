class AgentItem {
  static String name(int agentCode) {
    String agentName = "";

    switch (agentCode) {
      case 0:
        agentName = "普通茶友";
        break;
      case 1:
        agentName = "雅间经纪人";
        break;
      case 2:
        agentName = "大厅经纪人";
        break;
      case 3:
        agentName = "实习验茶师";
        break;
      case 4:
        agentName = "验茶师";
        break;
      case 5:
        agentName = "茶女郎";
        break;
      default:
        agentName = "普通茶友";
        break;
    }
    return agentName;
  }
}
