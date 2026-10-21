# app/controllers/tags_controller.rb
class TagsController < ApplicationController
  def index
    @tags = if params[:q].present?
      Tag.where("name LIKE ?", "%#{params[:q].downcase}%")
    else
      Tag.all
    end

    #render json: @tags.select(:id, :name)
  end

  # GET /tags/1 or /tags/1.json
  def show
  end

  # DELETE /tags/1 or /tags/1.json
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy!

    respond_to do |format|
      format.html { redirect_to books_path, notice: "Tag was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end
end