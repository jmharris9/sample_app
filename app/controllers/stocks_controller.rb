class StocksController < ApplicationController
  
  def create
    @stock = current_user.stocks.build(params[:stock])
    if @stock.save
      @stock.grab_data
      @stock.owners_earnings
      @stock.croic
      redirect_to stock_path(@stock)
    end
  end


  def index
  	@stocks = current_user.stocks.search(params[:search]).paginate(page: params[:page])
    @stock  = current_user.stocks.build
  end

  def destroy
    Stock.find(params[:id]).destroy
    flash[:success] = "Stock destroyed."
    redirect_to stocks_path
  end

  def show
  	@stock = Stock.find(params[:id])
    @line_items = @stock.line_items.paginate(page: params[:page])
    @income_statement = @stock.income_statement_feed.paginate(page: params[:page])
    @balance_sheet= @stock.balance_sheet_feed.paginate(page: params[:page])
    @cash_flow = @stock.cash_flow_feed.paginate(page: params[:page])
  end

  
end
