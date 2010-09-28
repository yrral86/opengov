Feature: Simplified Manager, Manager API
  As a developer
  In order to simplify the code for Manager users/consumers
# we don't Authenticator can be component... Manager needs it's own auth
# system that queries all available Authenticator componets
# so Manager gets the Session, Components keep the User
#  I want control API access via Authentication in the Manager
  And support external authentication adapter components
  And centralize authentication in Manager, which groups components
   (Moundsville Manager, McMechen Manager, etc.)
  And support verifying the credentials of a request across Managers
   (with daily reports of who from other managers users is accessing what data)
  And allow users to file a request for access to data
  And we want to keep the RackApp seperate from Manager
   (request -> manager, manager authenticates, generates :request_key)
   (manager forwards request and :request_key to component)
   (manager returns public key to RackApp, RackApp calls retrieve(key))
   (this allows us to have components with no socket to the RackApp)
