@Bitcoin = new Meteor.Collection 'bitcoin'

if Meteor.isServer
  Meteor.publish 'btc-price', ->
    Bitcoin.find {}

  Meteor.startup ->
    id = Bitcoin.findOne()?._id or Bitcoin.insert {}

    Meteor.setInterval ->
      HTTP.get 'https://api.coinbase.com/v1/prices/sell?qty=1', (e, r) ->
        if e
          console.log 'sell error:', e
        else
          Bitcoin.update id,
            $set: 
              'sell.usd': r.data.subtotal.amount
              'sell.updated': new Date()
            
      HTTP.get 'https://api.coinbase.com/v1/prices/buy?qty=1', (e, r) ->
        if e
          console.log 'buy error:', e
        else
          Bitcoin.update id,
            $set:
              'buy.usd': r.data.subtotal.amount
              'buy.updated': new Date()

    , 30 * 1000
    
    
