class SongsController < ApplicationController
  before_filter :prepare_for_mobile, :except => [:create]
  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.find_with_reputation(:votes, :all, order: "votes desc")

    respond_to do |format|
      format.html # songlist.html.erb
      format.json { render json: @songs }
    end
  end

  def vote
    value = params[:type] == "up" ? 1 : -1
    @song = Song.find(params[:id])
    @song.add_or_update_evaluation(:votes, value, current_user)
    redirect_to songs_url
  end

  def gettrack
    @songs = Song.find_with_reputation(:votes, :all, order: "votes desc")

    respond_to do |format|
      format.html # gettrack.html.erb
      format.json { render json: @songs }
    end
  end

  def tracklist
    @songs = Song.all

    respond_to do |format|
      format.html # tracklist.html.erb
      format.json { render json: @songs }
    end
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    @song = Song.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @song }
    end
  end

  def promote
    @song = Song.find(params[:id])
      if current_user
        User.delay.promote_request(current_user.id, song_url(@song))
      end
    respond_to do |format|
      format.html { redirect_to @song, notice: 'Song was successfully promoted!' }
      format.json { render json: @song, status: :created, location: @song }
    end
  end

  # GET /songs/new
  # GET /songs/new.json
  def new
    @song = Song.new
  end

  def add
    @song = Song.new

    respond_to do |format|
      format.html # add.html.erb
      format.json { render json: @song }
    end
  end

  # GET /songs/1/edit
  def edit
    @song = Song.find(params[:id])
  end

  def edit_gettrack
    @song = Song.find(params[:id])
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.new(params[:song])

      if params[:new_song]
        @song.save
        redirect_to @song, notice: 'Song was successfully created.'
      elsif params[:request_song]
        @song.save
          if current_user
            User.delay.share_request(current_user.id, song_url(@song))
          end
          redirect_to @song, notice: 'Song was successfully created.'
      elsif params[:request_song_mobile]
        @song.save
          if current_user
            User.delay.share_request(current_user.id, song_url(@song))
          end
        redirect_to @song, notice: 'Song was successfully created.'
      else
        render action: "new"
      end
  end

  # PUT /songs/1
  # PUT /songs/1.json
  def update
    @song = Song.find(params[:id])

    respond_to do |format|
      if params[:song_status]
        @song.update_attributes(params[:song])
        format.html { redirect_to "/songs/gettrack/", notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      elsif params[:new_song]
        @song.update_attributes(params[:song])
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song = Song.find(params[:id])
    @song.destroy

    respond_to do |format|
      format.html { redirect_to songs_url }
      format.json { head :no_content }
    end
  end

private

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end
end
