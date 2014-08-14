require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:festival)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: { content: @event.content, start: @event.start, latitude: @event.latitude, longitude: @event.longitude, name: 'New event', category: @event.category, stop: @event.stop, venue: @event.venue }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event
    assert_response :success
  end

  test "should update event" do
    patch :update, id: @event, event: { content: @event.content, start: @event.start, latitude: @event.latitude, longitude: @event.longitude, name: @event.name, category: @event.category, stop: @event.stop, venue: @event.venue }
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event
    end

    assert_redirected_to events_path
  end
end
