import 'dart:ui';

Size screenSize = Size(0, 0);

double charOffsetX = (screenSize.width - baseAnimationWidth) / 2;
double charOffsetY = (screenSize.height - baseAnimationHeight) / 2;

double scaledScreenSizeWidth = screenSize.width / 20000;
double scaledScreenSizeHeight = screenSize.height / 10000;

double baseAnimationWidth = 1000 * scaledScreenSizeWidth;
double baseAnimationHeight = 1200 * scaledScreenSizeHeight;
