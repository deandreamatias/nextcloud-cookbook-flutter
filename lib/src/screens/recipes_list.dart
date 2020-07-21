import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud_cookbook_flutter/src/blocs/authentication/authentication.dart';
import 'package:nextcloud_cookbook_flutter/src/blocs/recipes_short/recipes_short.dart';
import 'package:nextcloud_cookbook_flutter/src/models/recipe_short.dart';
import 'package:nextcloud_cookbook_flutter/src/screens/recipe_screen.dart';
import 'package:nextcloud_cookbook_flutter/src/widget/authentication_cached_network_image.dart';

class RecipesListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecipesListScreenState();
}

class RecipesListScreenState extends State<RecipesListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipesShortBloc, RecipesShortState>(
      builder: (context, recipesShortState) {
        return Scaffold(
          appBar: AppBar(title: Text('Cookbook App'), actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(
                Icons.refresh,
                semanticLabel: 'Refresh',
              ),
              onPressed: () {
                BlocProvider.of<RecipesShortBloc>(context)
                    .add(RecipesShortLoaded());
              },
            ),
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                semanticLabel: 'LogOut',
              ),
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
              },
            ),
          ]),
          body: (() {
            if (recipesShortState is RecipesShortLoadSuccess) {
              return _buildRecipesShortScreen(recipesShortState.recipesShort);
            } else if (recipesShortState is RecipesShortLoadInProgress) {
              return Center(child: CircularProgressIndicator());
            } else {
              //TODO Retry screen
              return Center(
                child: RaisedButton(
                  onPressed: () {
                    BlocProvider.of<RecipesShortBloc>(context)
                        .add(RecipesShortLoaded());
                  },
                  child: Text("Welcome"),
                ),
              );
            }
          }()),
        );
      },
    );
  }

  ListView _buildRecipesShortScreen(List<RecipeShort> data) {
    return ListView.separated(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildRecipeShortScreen(data[index]);
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.black,
      ),
    );
  }

  ListTile _buildRecipeShortScreen(RecipeShort recipeShort) {
    return ListTile(
      title: Text(recipeShort.name),
      trailing: Container(
        child:
            AuthenticationCachedNetworkImage(imagePath: recipeShort.imageUrl),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeShort: recipeShort),
            ));
      },
    );
  }
}