import 'dart:io';

import 'package:flutter_easy_order/bloc/category_bloc.dart';
import 'package:flutter_easy_order/bloc/storage_bloc.dart';
import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/models/image_type.dart';
import 'package:flutter_easy_order/models/storage.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockStorageBloc extends Mock implements StorageBloc {}

void main() {
  User mockUser;
  StorageBloc mockStorageBloc;
  CategoryRepository mockCategoryRepository;
  CategoryBloc categoryBloc;
  Category mockCategory;

  setUp(() {
    mockUser = User(id: 'mockUserId', email: 'mockUserEmail', isEmailVerified: true);
    mockCategoryRepository = MockCategoryRepository();
    mockStorageBloc = MockStorageBloc();

    mockCategory = Category(
        id: 'mockCategoryId',
        name: 'mockName',
        description: 'mockDescription',
        userId: 'mockUserId',
        userEmail: 'mockUserEmail',
        uuid: 'mockUuid'
    );
    Iterable<List<Category>> categories = Iterable.generate(1, (_) => [mockCategory]);
    Stream<List<Category>> mockCategories$ = Stream.fromIterable(categories);
    when(mockCategoryRepository.findByUser(user: mockUser)).thenAnswer((_) => mockCategories$);

    categoryBloc =
        CategoryBlocImpl(user: mockUser, categoryRepository: mockCategoryRepository, storageBloc: mockStorageBloc);
  });

  group('Create category', () {
    test(
      'should create category with image successfully',
          () async {
        // arrange
        Storage storage = Storage(path: 'path', url: 'url');
        File mockFile = File('path');
        when(mockStorageBloc.upload(
            file: mockFile, imageType: ImageType.Category)).thenAnswer((
            _) async => storage);

        when(mockCategoryRepository.create(category: anyNamed('category')))
            .thenAnswer((_) async => true);

        // act
        Category newCategory = Category(
          name: 'newName',
          description: 'newDescription',
        );
        final result = await categoryBloc.create(
            category: newCategory, image: mockFile);

        // assert
        Category expectedCategory = Category.clone(newCategory);
        expectedCategory.imagePath = 'path';
        expectedCategory.imageUrl = 'url';
        expectedCategory.userId = mockUser.id;
        expectedCategory.userEmail = mockUser.email;

        expect(result, true);
        verify(mockStorageBloc.upload(
            file: mockFile, imageType: ImageType.Category));
        expect(verify(mockCategoryRepository.create(
            category: captureAnyNamed('category'))).captured.single,
            equals(expectedCategory));
      },
    );

    test(
      'should create category with no image successfully',
          () async {
        // arrange
        when(mockCategoryRepository.create(category: anyNamed('category')))
            .thenAnswer((_) async => true);

        // act
        Category newCategory = Category(
            id: 'newCategoryId',
            name: 'newName',
            description: 'newDescription',
            userId: 'newUserId',
            userEmail: 'mockUserEmail',
            uuid: 'mockUuid'
        );
        final result = await categoryBloc.create(category: newCategory);

        // assert
        expect(result, true);
        verifyZeroInteractions(mockStorageBloc);
        expect(verify(mockCategoryRepository.create(
            category: captureAnyNamed('category'))).captured.single,
            equals(newCategory));
//      verifyNoMoreInteractions(mockNumberTriviaRepository);
      },
    );

    test(
      'should fail to create category if category null',
          () async {
        final result = await categoryBloc.create(category: null);

        // assert
        expect(result, false);
        verifyZeroInteractions(mockStorageBloc);
        verifyNever(
            mockCategoryRepository.create(category: anyNamed('category')));
//      expect(verify(mockCategoryRepository.create(category: captureAnyNamed('category'))).captured.single, equals(newCategory));
//      verifyNoMoreInteractions(mockNumberTriviaRepository);
      },
    );

  });

  group('Update category', () {
    test(
      'should update category with image successfully',
          () async {
        // arrange
        Storage storage = Storage(path: 'path', url: 'newUrl');
        File mockFile = File('path');
        when(mockStorageBloc.upload(
            file: mockFile, imageType: ImageType.Category, path: 'path')).thenAnswer((
            _) async => storage);

        when(mockCategoryRepository.update(category: anyNamed('category'), categoryId: anyNamed('categoryId')))
            .thenAnswer((_) async => true);

        // act
        Category updatedCategory = Category(
          name: 'updatedName',
          description: 'updatedDescription',
          imagePath: 'path',
          imageUrl: 'url',
        );
        final result = await categoryBloc.update(categoryId: 'categoryId',
            category: updatedCategory, image: mockFile);

        // assert
        Category expectedCategory = Category.clone(updatedCategory);
        expectedCategory.userId = mockUser.id;
        expectedCategory.userEmail = mockUser.email;

        expect(result, true);
        verify(mockStorageBloc.upload(
            file: mockFile, imageType: ImageType.Category, path: 'path'));
        expect(verify(mockCategoryRepository.update(categoryId: captureAnyNamed('categoryId'),
            category: captureAnyNamed('category'))).captured,
            equals(['categoryId', expectedCategory]));
      },
    );

    test(
      'should update category with no image successfully',
          () async {
        // arrange
        when(mockCategoryRepository.update(category: anyNamed('category'), categoryId: anyNamed('categoryId')))
            .thenAnswer((_) async => true);

        // act
        Category updatedCategory = Category(
          name: 'updatedName',
          description: 'updatedDescription',
          imagePath: 'path',
          imageUrl: 'url',
        );
        final result = await categoryBloc.update(categoryId: 'categoryId',
            category: updatedCategory);

        // assert
        Category expectedCategory = Category.clone(updatedCategory);
        expectedCategory.userId = mockUser.id;
        expectedCategory.userEmail = mockUser.email;

        expect(result, true);
        verifyZeroInteractions(mockStorageBloc);
        expect(verify(mockCategoryRepository.update(categoryId: captureAnyNamed('categoryId'),
            category: captureAnyNamed('category'))).captured,
            equals(['categoryId', expectedCategory]));
      },
    );

    test(
      'should fail to update category if category null',
          () async {
        final result = await categoryBloc.update(categoryId: 'categoryId', category: null);

        // assert
        expect(result, false);
        verifyZeroInteractions(mockStorageBloc);
        verifyNever(
            mockCategoryRepository.update(categoryId: anyNamed('categoryId'), category: anyNamed('category')));
//      expect(verify(mockCategoryRepository.create(category: captureAnyNamed('category'))).captured.single, equals(newCategory));
//      verifyNoMoreInteractions(mockNumberTriviaRepository);
      },
    );

  });

  group('Delete category', () {
    test(
      'should delete category with image successfully',
          () async {
        // arrange
        when(mockStorageBloc.delete(path: 'path')).thenAnswer((_) async => _);

        when(mockCategoryRepository.delete(category: anyNamed('category')))
            .thenAnswer((_) async => true);

        // act
        Category deletedCategory = Category(
            id: 'categoryId',
            uuid: 'uuid',
            userId: 'mockUserId',
            name: 'name',
            imagePath: 'path',
            imageUrl: 'url'
        );
        final result = await categoryBloc.delete(category: deletedCategory);

        // assert
        Category expectedCategory = Category.clone(deletedCategory);
        expectedCategory.userId = mockUser.id;
        expectedCategory.userEmail = mockUser.email;

        expect(result, true);
        verify(mockStorageBloc.delete(path: 'path'));
        expect(verify(mockCategoryRepository.delete(category: captureAnyNamed('category'))).captured,
            equals([expectedCategory]));
      },
    );

    test(
      'should fail to delete category if category null',
          () async {
        final result = await categoryBloc.delete(category: null);

        // assert
        expect(result, false);
        verifyZeroInteractions(mockStorageBloc);
        verifyNever(
            mockCategoryRepository.delete(category: anyNamed('category')));
      },
    );

  });
}
