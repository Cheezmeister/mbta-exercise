MBTA_API_KEY = '7c021569cf7b451f80df5d6b5a7b4330'
MBTA_API_URL = 'https://api-v3.mbta.com'

STOPS = 'place-north,place-sstat'
SORTS = 'departure_time'

prediction_endpoint = MBTA_API_URL +
  '/predictions?' + [
    "filter[stop]=#{STOPS}",
    "filter[direction_id]=#{0}",
    "include=stop,vehicle,route,trip",
    "sort=#{SORTS}",
    "api_key=#{MBTA_API_KEY}",
  ].join '&'

requestOptions = headers: {'X-Api-Key': MBTA_API_KEY}

renderDash = (payload) ->
  document.querySelector('#north .board .content').innerHTML = ''
  document.querySelector('#south .board .content').innerHTML = ''

  extractInclude = (type) -> payload.included.filter (i) -> i.type == type
  includes =
    trip: extractInclude 'trip'
    vehicle: extractInclude 'vehicle'
    stop: extractInclude 'stop'
    route: extractInclude 'route'

  lookup = (type) -> (prediction) -> includes[type].find( (o) -> o.id == prediction.relationships[type]?.data?.id)
  lookupRoute = lookup 'route'
  lookupStop = lookup 'stop'
  lookupVehicle = lookup 'vehicle'
  lookupTrip = lookup 'trip'

  formatStatus = (prediction) ->
    prediction.attributes.status || 'Unknown'
  formatTrackNumber = (prediction) ->
    lookupStop(prediction).attributes.platform_code || 'TBD'
  formatTrainNumber = (prediction) ->
    lookupTrip(prediction)?.attributes?.name || 'WTF'
  formatDestination = (prediction) ->
    "#{lookupRoute(prediction).attributes.long_name} to <small class='destination' style='background: ##{lookupRoute(prediction).attributes.color}'>#{lookupTrip(prediction).attributes.headsign}</small>"
  formatDepartureTime = (prediction) ->
    d = new Date(prediction.attributes.departure_time)
    d.toLocaleTimeString('en-US')

  payload.data.forEach (prediction) ->
    return unless lookupRoute(prediction).attributes.description is 'Commuter Rail'
    el = document.createElement 'div'
    el.className = 'row'
    el.innerHTML = [
      "<div class='two columns' data-timestamp=#{prediction.attributes.departure_time}>#{formatDepartureTime(prediction)}</div>",
      "<div class='five columns'>#{formatDestination(prediction)}</div>",
      "<div class='one columns'>#{formatTrainNumber(prediction)}</div>",
      "<div class='one columns'>#{formatTrackNumber(prediction)}</div>",
      "<div class='three columns'>#{formatStatus(prediction)}</div>",
    ].join ''
    selector = if /place-north/.test (lookupStop(prediction).id + lookupStop(prediction).relationships.parent_station?.data?.id) then '#north .board .content' else '#south .board .content'
    document.querySelector(selector).appendChild el


initialize = ->
  url = prediction_endpoint
  console.log "Fetching #{url}..."
  response = await fetch(url)
  text = await response.text()
  console.dir JSON.parse text
  renderDash JSON.parse text
  window.setTimeout initialize, 5000

window.setTimeout initialize, 0
