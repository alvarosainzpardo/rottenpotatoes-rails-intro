class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    case params[:sort]
    when "movie_title"
      @sort_column = :title
      session[:sort] = :title
    when "release_date"
      @sort_column = :release_date
      session[:sort] = :release_date
    else
      @sort_column = session[:sort]
    end
    @all_ratings = []
    Movie.uniq.pluck(:rating).each do |rating|
      @all_ratings << {rating:rating, checked:true}
    end
    if params[:ratings]
      session.delete(:sort)
      session[:ratings] = params[:ratings]
      ratings_checked = params[:ratings].keys
      @all_ratings.each {|h| h[:checked] = false}
      @all_ratings.each {|h| h[:checked] = true if ratings_checked.include?(h[:rating])}
    elsif session[:ratings]
      ratings_checked = session[:ratings].keys
      @all_ratings.each {|h| h[:checked] = false}
      @all_ratings.each {|h| h[:checked] = true if ratings_checked.include?(h[:rating])}
    else
      ratings_checked = Movie.uniq.pluck(:rating)
    end
    @movies = Movie.where(rating:ratings_checked).order(@sort_column)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
