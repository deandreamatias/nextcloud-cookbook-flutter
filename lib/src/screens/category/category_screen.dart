import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nextcloud_cookbook_flutter/src/blocs/authentication/authentication.dart';
import 'package:nextcloud_cookbook_flutter/src/blocs/categories/categories.dart';
import 'package:nextcloud_cookbook_flutter/src/blocs/recipes_short/recipes_short.dart';
import 'package:nextcloud_cookbook_flutter/src/models/category.dart';
import 'package:nextcloud_cookbook_flutter/src/models/recipe.dart';
import 'package:nextcloud_cookbook_flutter/src/models/recipe_short.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/my_settings_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/recipe/recipe_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/recipe_create_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/recipe_import_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/recipes_list_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/timer_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/services/data_repository.dart';
import 'package:nextcloud_cookbook_flutter/src/widget/api_version_warning.dart';
import 'package:nextcloud_cookbook_flutter/src/widget/authentication_cached_network_image.dart';
import 'package:nextcloud_cookbook_flutter/src/widget/authentication_cached_network_recipe_image.dart';
import 'package:nextcloud_cookbook_flutter/src/widget/category_card.dart';
import 'package:search_page/search_page.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, categoriesState) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return RecipeCreateScreen(Recipe.empty());
                  },
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: ClipOval(
                      child: AuthenticationCachedNetworkImage(
                        url: DataRepository().getUserAvatarUrl(),
                        boxFit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.alarm_add_outlined,
                    semanticLabel: translate('timer.title'),
                  ),
                  title: Text(translate('timer.title')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const TimerScreen();
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  trailing: Icon(
                    Icons.cloud_download_outlined,
                    semanticLabel: translate('categories.drawer.import'),
                  ),
                  title: Text(translate('categories.drawer.import')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const RecipeImportScreen();
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  trailing: Icon(
                    Icons.settings,
                    semanticLabel: translate('categories.drawer.settings'),
                  ),
                  title: Text(translate('categories.drawer.settings')),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const MySettingsScreen();
                        },
                      ),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  trailing: Icon(
                    Icons.exit_to_app,
                    semanticLabel: translate('app_bar.logout'),
                  ),
                  title: Text(translate('app_bar.logout')),
                  onTap: () {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoggedOut());
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: Text(translate('categories.title')),
            actions: <Widget>[
              BlocBuilder<RecipesShortBloc, RecipesShortState>(
                builder: (context, recipeShortState) {
                  return BlocListener<RecipesShortBloc, RecipesShortState>(
                    listener: (context, recipeShortState) {
                      if (recipeShortState is RecipesShortLoadAllSuccess) {
                        showSearch(
                          context: context,
                          delegate: SearchPage<RecipeShort>(
                            items: recipeShortState.recipesShort,
                            searchLabel: translate('search.title'),
                            suggestion: const Center(
                                // child: Text('Filter people by name, surname or age'),
                                ),
                            failure: Center(
                              child: Text(translate('search.nothing_found')),
                            ),
                            filter: (recipe) => [
                              recipe.name,
                            ],
                            builder: (recipe) => ListTile(
                              title: Text(recipe.name),
                              trailing: AuthenticationCachedNetworkRecipeImage(
                                recipeId: recipe.recipeId,
                                full: false,
                                width: 50,
                              ),
                              onTap: () =>
                                  Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeScreen(recipeId: recipe.recipeId),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (recipeShortState
                          is RecipesShortLoadAllFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              translate(
                                'search.errors.search_failed',
                                args: {"error_msg": recipeShortState.errorMsg},
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: IconButton(
                      icon: Icon(
                        () {
                          if (recipeShortState
                              is RecipesShortLoadAllInProgress) {
                            return Icons.downloading;
                          } else if (recipeShortState
                              is RecipesShortLoadAllFailure) {
                            return Icons.report_problem;
                          } else {
                            return Icons.search;
                          }
                        }(),
                        semanticLabel: translate('app_bar.search'),
                      ),
                      onPressed: () async {
                        BlocProvider.of<RecipesShortBloc>(context)
                            .add(RecipesShortLoadedAll());
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  semanticLabel: translate('app_bar.refresh'),
                ),
                onPressed: () {
                  DefaultCacheManager().emptyCache();
                  BlocProvider.of<CategoriesBloc>(context)
                      .add(CategoriesLoaded());
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () {
              DefaultCacheManager().emptyCache();
              BlocProvider.of<CategoriesBloc>(context).add(CategoriesLoaded());
              return Future.value();
            },
            child: () {
              if (categoriesState is CategoriesLoadSuccess) {
                return _buildCategoriesScreen(categoriesState.categories);
              } else if (categoriesState is CategoriesImageLoadSuccess) {
                return _buildCategoriesScreen(categoriesState.categories);
              } else if (categoriesState is CategoriesLoadInProgress ||
                  categoriesState is CategoriesInitial) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SpinKitWave(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const ApiVersionWarning(),
                  ],
                );
              } else if (categoriesState is CategoriesLoadFailure) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        translate('categories.errors.plugin_missing'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Text(
                        translate(
                          'categories.errors.load_failed',
                          args: {'error_msg': categoriesState.errorMsg},
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Text(translate('categories.errors.unknown'));
              }
            }(),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesScreen(List<Category> categories) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int axisRatio = (screenWidth / 150).round();
    final int axisCount = axisRatio < 1 ? 1 : axisRatio;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.count(
        crossAxisCount: axisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.only(top: 10),
        semanticChildCount: categories.length,
        children: categories
            .map(
              (category) => GestureDetector(
                child: CategoryCard(category),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return RecipesListScreen(category: category.name);
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
