class RecipesController < ApplicationController
  def create
    @recipe = Recipe.new(params[:recipe])
    @recipe.save
    redirect_to :action => "show", :id => @recipe.batch_number
  end

  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
  end

  def show
    @recipe = Recipe.find_by_batch_number(params[:id])
  end
end
