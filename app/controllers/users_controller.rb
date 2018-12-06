class UsersController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update, 
						:following, :followers]
	before_action :correct_user,   only: [:edit, :update, :add]

	# マイページにアクセス
	def show
    	@user = User.find(params[:id])
    	@archive_year = params[:archive_year]
    	@artist_select = params[:artist_select]
    	@place_select = params[:place_select]
    	@type = params[:type]
    	@microposts =  @user.microposts.paginate(:page => params[:page], :per_page => 6)

    	# アーカイブとチケットの種類を選択
    	if @archive_year.present? and @type.present?
    		@microposts = @microposts.where(year: @archive_year)

    		if @type == "live"
    			@microposts = @microposts.where(teama: "")
    		elsif @type == "sport"
    			@microposts = @microposts.where.not(teama: "")
    		end
    	end

    	# アーカイブ選択
    	if @archive_year.present?
    		@microposts = @microposts.where(year: @archive_year)
    	end

    	# アーティスト選択
    	if @artist_select.present?
    		@microposts = @microposts.where(artist: @artist_select)
    	end

    	# 会場選択
    	if @place_select.present?
    		@microposts = @microposts.where(place: @place_select)
    	end

    	# チケットの種類選択
    	if @type.present?
    		if @type == "live"
    			@microposts = @microposts.where(teama: "")
    		elsif @type == "sport"
    			@microposts = @microposts.where.not(teama: "")
    		end
    	end

    	# アーティスト別回数
    	@artists = []
    	@cnt_artist = []
    	@artists = @user.microposts.where(teama: '').pluck(:artist).uniq	# スポーツではないチケットのアーティストを取得
    	@artists.each { |artist| @cnt_artist.push(@user.microposts.where(artist: artist).count) }

    	# 会場別回数
    	@places = []
    	@cnt_place = []
    	@places = @user.microposts.pluck(:place).uniq
		@places.each { |place| @cnt_place.push(@user.microposts.where(place: place).count) }    	


    	# アーカイブ
    	@years = []
    	@cnt_year = []		# その年度に追加したチケットの枚数
    	@cnt_allyear = []	# 全チケット数
    	@years = @user.microposts.pluck(:year).uniq
    	@years.each { |year| @cnt_year.push(@user.microposts.where(year: year).count) }
    	@cnt_allyear = @user.microposts.count

    	# 並び替え
    	@microposts = @microposts.order(year: "DESC")
    	@microposts = @microposts.order(month: "DESC")
    	@microposts = @microposts.order(day: "DESC")

	end

	def index
        @users = User.search(params[:search])
	end

	def following
		@user  = User.find(params[:id])
		@users = @user.following.paginate(page: params[:page])
		render 'show_follow'
	end

	def followers
		@user  = User.find(params[:id])
		@users = @user.followers.paginate(page: params[:page])
		render 'show_follow'
	end

	private

	    # 正しいユーザーかどうかを確認
	    def correct_user
			@user = User.find(params[:id])
			redirect_to(root_url) unless @user == current_user
		end

end
