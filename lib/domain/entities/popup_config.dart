enum PopupPosition { 
  center, 
  bottomLeft, 
  bottomRight, 
  topCenter 
}

class PopupConfig {
  final PopupPosition position;
  final double width;
  final double height;
  final bool alwaysOnTop;

  const PopupConfig({
    this.position = PopupPosition.center,
    this.width = 400,
    this.height = 250,
    this.alwaysOnTop = true,
  });
}
