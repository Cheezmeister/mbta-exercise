MBTA_API_KEY = '7c021569cf7b451f80df5d6b5a7b4330'
MBTA_API_URL = 'https://api-v3.mbta.com'

MAX_PREDICTIONS = 24
STOPS = 'place-north,place-sstat'
SORTS = 'departure_time'

prediction_endpoint = MBTA_API_URL +
  '/predictions?' + [
    "filter[stop]=#{STOPS}",
    "filter[direction_id]=#{0}",
    "include=stop,vehicle,route",
    "sort=#{SORTS}",
    "api_key=#{MBTA_API_KEY}",
  ].join '&'

requestOptions = headers: {'X-Api-Key': MBTA_API_KEY}

renderDash = (payload) ->
  vehicles = payload.included.filter (i) -> i.type == 'vehicle'
  routes = payload.included.filter (i) -> i.type == 'route'
  stops = payload.included.filter (i) -> i.type == 'stop'

  lookupRoute = (prediction) -> routes.find((r) -> r.id == prediction.relationships.route.data.id)
  lookupStop = (prediction) -> stops.find((s) -> s.id == prediction.relationships.stop.data.id)
  lookupVehicle = (prediction) -> vehicles.find((v) -> v.id == prediction.relationships.vehicle?.data?.id)

  formatStatus = (prediction) ->
    prediction.attributes.status || 'Unknown'
  formatTrackNumber = (prediction) ->
    lookupStop(prediction).attributes.platform_code || 'TBD'
  formatTrainNumber = (prediction) ->
    lookupVehicle(prediction)?.attributes?.label || 'Unknown'
  formatDestination = (prediction) ->
    lookupRoute(prediction).attributes.long_name
  formatDepartureTime = (prediction) ->
    d = new Date(prediction.attributes.departure_time)
    d.toLocaleTimeString('en-US')

  payload.data.forEach (prediction) ->
    return unless lookupRoute(prediction).attributes.description is 'Commuter Rail'
    el = document.createElement 'div'
    el.className = 'row'
    el.innerHTML = [
      "<div class='two columns' data-timestamp=#{prediction.attributes.departure_time}>#{formatDepartureTime(prediction)}</div>",
      "<div class='five columns destination' style='color: ##{lookupRoute(prediction).attributes.color}'>#{formatDestination(prediction)}</div>",
      "<div class='one columns'>#{formatTrainNumber(prediction)}</div>",
      "<div class='one columns'>#{formatTrackNumber(prediction)}</div>",
      "<div class='three columns'>#{formatStatus(prediction)}</div>",
    ].join ''
    selector = if /place-north/.test (lookupStop(prediction).id + lookupStop(prediction).relationships.parent_station?.data?.id) then '#north .board' else '#south .board'
    document.querySelector(selector).appendChild el


initialize = ->
  url = prediction_endpoint
  console.log "Fetching #{url}"
  response = await fetch(url, )
  text = await response.text()
  console.log "Response: #{text}"
  console.dir JSON.parse text
  renderDash JSON.parse text
  window.setTimeout initialize, 1000

window.setTimeout initialize, 0
