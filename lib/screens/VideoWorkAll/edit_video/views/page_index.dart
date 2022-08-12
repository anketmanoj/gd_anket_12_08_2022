enum ViewMode {
  Preview,
  Edit,
}

const _viewModeEnumMap = {
  ViewMode.Preview: 0,
  ViewMode.Edit: 1,
};

extension ViewModePageIndex on ViewMode {
  int? asInt() => _viewModeEnumMap[this];
}
