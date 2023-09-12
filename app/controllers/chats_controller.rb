class ChatsController < ApplicationController
  def search
    search_data = params[:search_data]
    result = ChatgptService.call(search_data)

    render json: { data: result }, status: 200
  end
end