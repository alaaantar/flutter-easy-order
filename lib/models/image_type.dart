enum ImageType {
  Product,
  Category,
}

class ImageTypeDirectory {

  static String getDirectory(ImageType imageType) {
    switch (imageType) {
      case ImageType.Product:
        return 'products';
        break;
      case ImageType.Category:
        return 'categories';
        break;
      default:
        return null;
    }
  }
}
