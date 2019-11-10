import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import './image_input_adapter.dart';

class ImageFormField extends FormField<ImageInputAdapter> {
  ImageFormField({
    FormFieldSetter<ImageInputAdapter> onSaved,
    FormFieldValidator<ImageInputAdapter> validator,
    ImageInputAdapter initialValue,
    bool autovalidate = false,
    double fileMaxWidth = 300.0,
    double previewImageHeight = 300.0,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autovalidate,
            builder: (FormFieldState<ImageInputAdapter> state) {
              final buttonColor = Theme.of(state.context).primaryColor;
              // Widget previewImage = Text('Please select an image.');
              Widget previewImage = Container();
              if (state.value.isFile) {
                previewImage = Image.file(
                  state.value.file,
                  fit: BoxFit.scaleDown,
                  height: previewImageHeight,
                  width: MediaQuery.of(state.context).size.width,
                  alignment: Alignment.topCenter,
                );
              } else if (state.value.isUrl) {
                previewImage = Image.network(
                  state.value.url,
                  fit: BoxFit.scaleDown,
                  height: previewImageHeight,
                  width: MediaQuery.of(state.context).size.width,
                  alignment: Alignment.topCenter,
                );
              }

              return Column(
                children: <Widget>[
                  OutlineButton(
                    borderSide: BorderSide(
                      color: buttonColor,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    padding: EdgeInsets.all(12),
                    onPressed: () {
                      _openImagePicker(state, fileMaxWidth);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          color: buttonColor,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'CHOOSE IMAGE',
                          style: TextStyle(color: buttonColor),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  previewImage,
                  SizedBox(height: 10.0),
                  state.hasError
                      ? Text(
                          state.errorText,
                          style: Theme.of(state.context).inputDecorationTheme.errorStyle,
                        )
                      : Container()
                  // _imageFile == null
                  //     ? Text('Please pick an image.')
                  //     :
                ],
              );
            });

  static void _openImagePicker(FormFieldState<ImageInputAdapter> state, double fileMaxWidth) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        context: state.context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
//            decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.only(
//                topLeft: Radius.circular(20.0),
//                topRight: Radius.circular(20.0),
//              )
//            ),
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Camera'),
                onPressed: () {
                  _getImage(state, ImageSource.camera, fileMaxWidth);
                },
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Gallery'),
                onPressed: () {
                  _getImage(state, ImageSource.gallery, fileMaxWidth);
                },
              )
            ]),
          );
        });
  }

  static void _getImage(FormFieldState<ImageInputAdapter> state, ImageSource source, double fileMaxWidth) {
    ImagePicker.pickImage(source: source, maxWidth: fileMaxWidth).then((File image) {
      ImageInputAdapter imageInputAdapter = ImageInputAdapter(file: image);
      state.didChange(imageInputAdapter);
      Navigator.pop(state.context);
    });
  }
}
