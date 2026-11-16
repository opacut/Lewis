class BooksController < ApplicationController
  before_action :set_book, only: %i[ show update destroy ]

  # GET /books or /books.json
  def index
    @books = Book.all
    @tags = Tag.all

    if params[:search_name].present?
      @books = @books.search_name(params[:search_name])
    end

    if params[:search_author].present?
      @books = @books.search_author(params[:search_author])
    end

    if params[:location].present?
      @books = @books.location(params[:location])
    end

    if params[:tags].present?
      selected_tags = Array(params[:tags]).flat_map { |value| value.split(",") }.reject(&:blank?).uniq
      @books = @books.with_tags(selected_tags) if selected_tags.any?
    end

    sort_columns = {
      "title" => :title,
      "author" => :author,
      "location" => :location,
      "newest" => :created_at
    }

    sort_column = sort_columns.fetch(params[:sort], :title)
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"

    @books = @books.order(sort_column => sort_direction)
  end

  # GET /books/1 or /books/1.json
  def show
    respond_to do |format|
      format.html { render "books/index" }
      format.json
    end
  end

  # GET /books/new
  def new
    render "books/index"
  end

  # GET /books/1/edit
  def edit
    render "books/index"
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @book.errors }, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Book was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: { errors: @book.errors }, status: :unprocessable_content }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!

    respond_to do |format|
      format.html { redirect_to books_path, notice: "Book was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /books/scan
  def scan
    if params[:photo].blank?
      respond_to do |format|
        format.html { redirect_to new_book_path, alert: "Upload photo" }
        format.json { render json: { error: "Upload photo" }, status: :unprocessable_content }
      end
      return
    end

    metadata = BookVisionService.new(params[:photo]).extract_metadata

    if metadata
      @book = Book.new(
        title: metadata["title"],
        author: metadata["author"],
        image: params[:photo]
      )

      respond_to do |format|
        if @book.save
          format.html { redirect_to @book, notice: "Book created!" }
          format.json { render :show, status: :created, location: @book }
        else
          format.html { redirect_to new_book_path, alert: @book.errors.full_messages.join(", ") }
          format.json { render json: { errors: @book.errors }, status: :unprocessable_content }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to new_book_path, alert: "Could not read book info" }
        format.json { render json: { error: "Could not read book info" }, status: :unprocessable_content }
      end
    end
  end

  private

  def set_book
    @book = Book.find(params.expect(:id))
  end

  def book_params
    permitted = params.require(:book).permit(:title, :author, :description, :location, :image, tag_names: [])
    permitted[:tag_names] ||= params[:tag_names] if params[:tag_names].is_a?(Array)

    # Ignore stringified JS::Object from JSON payloads; real file uploads come via FormData
    if permitted[:image].is_a?(String)
      permitted.delete(:image)
    end

    permitted
  end
end