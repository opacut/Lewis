class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

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
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
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
        format.json { render json: @book.errors, status: :unprocessable_content }
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
        format.json { render json: @book.errors, status: :unprocessable_content }
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
      redirect_to new_book_path, alert: "Upload photo"
      return
    end

    metadata = BookVisionService.new(params[:photo]).extract_metadata

    if metadata
      @book = Book.new(
        title: metadata["title"],
        author: metadata["author"],
        image: params[:photo]
      )

      if @book.save
        redirect_to @book, notice: "Book created!"
      else
        redirect_to new_book_path, alert: @book.errors.full_messages.join(", ")
      end
    else
      redirect_to new_book_path, alert: "Could not read book info"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :author, :description, :location, :image, tag_names: [])
    end
end
