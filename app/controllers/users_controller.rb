class UsersController < ApplicationController
  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @authorization = @user.authorizations
    @user.destroy
    @authorization.destroy
    respond_to do |format|
      format.html { redirect_to "/thanks" }
      format.json { head :no_content }
    end
  end
end
