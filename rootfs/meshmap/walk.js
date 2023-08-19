const axios = require('axios');
const sysinfo = require('./src/APIResources.json')
const fs = require('fs')

class Scanner {
  constructor (foundHostCallback, maxSimultaneousRequests = 2) {
    this.scannedHosts = []
    this.scanQueue = []
    this.maxSimultaneousRequests = maxSimultaneousRequests
    this.inFlightRequests = []
    this.foundHostCallback = foundHostCallback
  }

  async scan(start, regex) {
    this.scannedHosts.push(start)
    const startHost = await this.walkHosts(start, regex)
    if (startHost && startHost.data && startHost.data.node) {
      this.foundHostCallback(startHost)
    }

    while (this.scanQueue.length > 0 || this.inFlightRequests.length > 0) {
      // We need to run walkHosts against the queue
      // maxSimultaneousRequests requests at a time
      // until the queue is empty
      try {
        if ((this.inFlightRequests.length >= this.maxSimultaneousRequests)
          || (this.scanQueue.length === 0 && this.inFlightRequests.length > 0)) {
          // This needs to remove from the inFlightRequests array
          const numReqs = this.inFlightRequests.length
          for (let i = 0; i < numReqs; i++) {
            try {
              await this.inFlightRequests.shift()
            } catch (_) { /* ignore */ }
          }
          console.log('Done waiting')
        }
        console.log(`Queue Size: ${this.scanQueue.length}, In Flight: ${this.inFlightRequests.length}`)
        const host = this.scanQueue.shift()
        if (!host) {
          continue
        }
        this.inFlightRequests.push(
          new Promise((resolve, reject) => {
            this.scannedHosts.push(host)
            this.walkHosts(host, regex).then((host) => {
              if (host && host.data && host.data.node) {
                console.log(`Found host: ${host.data.node}`)
                this.foundHostCallback(host)
              }
              resolve(host)
            }).catch((err) => {
              reject(err)
            })
          })
        )
      } catch (err) {
        console.error(err)
      }
    }
  }

  async walkHosts(start, regex) {
    const thisHost = {};
    try {
      const nodes = await axios({
        method: 'get',
        url: `http://${start}.local.mesh:8080${sysinfo.resource}${sysinfo.params.hosts}&${sysinfo.params.link_info}&${sysinfo.params.lqm}`,
        timeout: 5000 // only wait for 2s
      })
      const retrievedNodes = nodes.data.hosts.filter(h => h.name.toUpperCase().trim().match(regex))
      for (const node of retrievedNodes) {
        if (!this.scannedHosts.includes(node.name) && !this.scanQueue.includes(node.name)) {
          if (!this.scanQueue.includes(node.name)) {
            this.scanQueue.push(node.name)
          }
        }
      }
      if (nodes.data.lat && nodes.data.lon) {
        thisHost.node = nodes.data.node
        thisHost.lastseen = nodes.data.lastseen
        thisHost.lat = nodes.data.lat
        thisHost.lon = nodes.data.lon
        thisHost.mlat = nodes.data.lat
        thisHost.mlon = nodes.data.lon
        thisHost.meshrf = nodes.data.meshrf
        thisHost.chanbw = nodes.data.chanbw
        thisHost.node_details = nodes.data.node_details
        thisHost.interfaces = nodes.data.interfaces
        thisHost.link_info = Object.keys(nodes.data.link_info || {}).map((key) => nodes.data.link_info[key])
        thisHost.lqm = nodes.data.lqm
      }
    } catch (_) { /* ignore */ }
    return { data: thisHost }
  }
}

const allHosts = [];
function callback(host) {
  console.log(`Found host: ${host.data.node}`)
  for (const h of allHosts) {
    if (h.data.node === host.data.node) {
      console.log(`Already found host: ${host.data.node}`)
      return
    }
  }
  allHosts.push(host)
}

new Scanner(callback).scan("KI5VMF-CLOUD-TUNNEL-supernode", '.*').then(() => {
  console.log(`Found ${allHosts.length} hosts`)
  fs.writeFileSync('/www/data/out.json', JSON.stringify({ nodeInfo: allHosts, date: new Date() }, null, 2))
}).catch((err) => {
  console.error(err)
})