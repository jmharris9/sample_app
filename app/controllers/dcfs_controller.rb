class DcfsController < ApplicationController
  def new
  	@stock = Stock.find(params[:stock_id])
    @dcf = @stock.dcfs.build
    @line_items = @dcf.init
    @projections = @dcf.projection
    @dcf.eps_averages

    @dcf.save
  end

  def index
    @stock = Stock.find(params[:stock_id])
    @dcfs = @stock.dcfs
  end

  def create
    @stock = Stock.find(params[:stock_id])
    @dcf = @stock.dcfs.build(params[:dcf])
    @dcf.save
  end

  def show
    @stock = Stock.find(params[:stock_id])
    @dcf = @stock.dcfs.find(params[:id])
    @value2 = @dcf.run_dcf
    @line_items = @dcf.stock_data
    @projections = @dcf.projection
    @eps = @dcf.ben_graham_number
    @ten_year_eps_av = @dcf.get_line("EPS 10yr").sum!/10
    @five_year_eps_av = @dcf.get_line("EPS 5yr").sum!/10
    @croic_av = @stock.get_line("CROIC").sum!/10
    @aaa_bond = @dcf.get_AAA_rate
    @discount = @dcf.discount
    @eps_num   = @stock.get_line("Diluted EPS - Total").yr0
    @bg = @dcf.bg_calc
    @dcf.nnav_data
    @nnav = @dcf.nnav
    @dcf.p_score
    @p_value = @dcf.get_line("Piotroski Formula")
    @dcf.altman_z
    @altz = @dcf.get_line("Altman Z (manufacturing)")
    @altzn = @dcf.get_line("Altman Z (nonmanufacturing)")
    @dcf.ben_m
    @benm = @dcf.get_line("Beneish M Score - 8 variable")
    @benmfive = @dcf.get_line("Beneish M Score - 5 variable")
  end

  def update
    @stock = Stock.find(params[:stock_id])
    @dcf = @stock.dcfs.find(params[:id])
    @dcf.update_attributes(params[:dcf])
    redirect_to stock_dcfs_path(@stock)
  end

  def edit
    @stock = Stock.find(params[:stock_id])
    @dcf = @stock.dcfs.find(params[:id])
  end

  def destroy
    @stock = Stock.find(params[:stock_id])
    @dcf = @stock.dcfs.find(params[:id])
    @dcf.destroy
    redirect_to stock_dcfs_url
  end
end
