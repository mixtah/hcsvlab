require 'spec_helper'

describe SpeakersController, :type => :controller do
  render_views
  login_admin

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    @collection = create(:collection)
    @collection_no_speaker = create(:collection_no_speaker)
  end

  # GET /speakers/:collection/
  describe 'GET list of speaker identifiers (URIs) associated with specific collection' do
    context 'with specific collection not exists' do
      it 'returns no such collection' do
        get :index, collection: 'not_found'

        # test for the 422 status-code
        expect(response.response_code).to eq(422)
      end
    end

    context 'with specific collection exists but no speaker within' do
      it 'returns empty list' do
        get :index, collection: @collection_no_speaker.name

        # test for the 200 status-code
        expect(response.response_code).to eq(200)

        json = JSON.parse(response.body)

        expect(json).to include_json(speakers: [])
      end
    end

    context 'with specific collection exists and speaker exists' do
      it 'returns speaker list' do
        get :index, collection: @collection.name

        # test for the 200 status-code
        expect(response.response_code).to eq(200)
        # expect return:
        # {
        #   "speakers": [
        #     "URI1",
        #     "URI2"
        #   ]
        # }

        json = JSON.parse(response.body)

        expect(json).to include_json(
          speakers: [
            "http://app.alveo.edu.au/speakers/#{@collection.name}/1_116",
            "http://app.alveo.edu.au/speakers/#{@collection.name}/1_117"
          ]
        )

      end
    end
  end


  # GET /speakers/:collection/:speaker_id
  describe 'GET speaker metadata' do
    context 'with params[:collection] but collection not exists' do
      it 'return no such collection' do
        get :show, collection: 'not_found', speaker_id: 'whatever'

        # test for the 422 status-code
        expect(response.response_code).to eq(422)
      end
    end

    context 'with collection exists but speaker not exists' do
      it 'returns no such speaker' do
        get :show, collection: @collection.name, speaker_id: "not_found"

        # test for the 422 status-code
        expect(response.response_code).to eq(422)
      end
    end

    context 'with params[:collection] and collection exists' do
      context 'with params[:speaker_id] and speaker exists' do
        it 'populate a specific speaker metadata' do
        end
      end

      context 'with params[:speaker_id] but no such speaker' do
        it 'return no such speaker' do
        end
      end

      context 'without params[:speaker_id]' do
        it 'return no such speaker' do
        end
      end

    end

  end

end
