import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/features/post_engine/presentation/screens/post_category_picker_screen.dart';

/// Single entry point for opening Post Engine vertical flows from the shell.
abstract final class ShellPostEntry {
  static void openVertical(BuildContext context, PostVertical vertical) {
    context.push(PostCategoryPickerScreen.postRoute(vertical));
  }
}
