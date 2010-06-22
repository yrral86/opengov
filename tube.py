#!/usr/bin/env python

import telepathy

class UpdateObserver(telepathy.server.Observer,
                     telepathy.server.DBusProperties):

    def __init__(self, *args):
        telepathy.server.Observer.__init__(self, *args)
        telepathy.server.DBusProperties.__init__(self)

        self._implement_property_get(CLIENT, {
                'Interfaces': lambda: [ CLIENT_OBSERVER ],
                })
        self._implement_property_get(CLIENT_OBSERVER, {
                'ObserverChannelFilder': lambda: dbus.Array([
                        dbus.Dictionary({
                                }, signature='sv')
                        ], signature='a{sv}')
                })

    def ObserveChannels(self, account, connection, channels, dispatch_operation,
                        requests_satisfies, observer_info):
        print "Incomming channels on %s" % (connection)
        for object, props in channels:
            print " - %s" % (props[CHANNEL + '.ChannelType'],
                             props[CHANNEL + '.TargetID'])


if __name__ == "main":
    bus_name = '.'.join ([CLIENT, client_name])
    object_path = '/' + bus_name.replace('.', '/')

    bus_name = dbus.service.BusName(bus_name, bus=dbus.SessionBus())

    UpdateObserver(bus_name, object_path)
