class RecipesController < ApplicationController
  def create
    @recipe = Recipe.new(params[:recipe])
    @recipe.save
    redirect_to :action => "show", :id => @recipe.id
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.update_attributes(params[:recipe])

    redirect_to :action => "show", :id => @recipe.id
  end
end
