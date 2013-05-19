#ifndef XCHAT_SERVLIST_H
#define XCHAT_SERVLIST_H

typedef struct ircserver
{
	char *hostname;
} ircserver;

typedef struct ircnet
{
	char *name;
	char *nick;
	char *nick2;
	char *user;
	char *real;
	char *pass;
	char *autojoin;
	char *command;
	int logintype;
	char *comment;
	char *encoding;
	GSList *servlist;
	int selected;
	guint32 flags;
} ircnet;

extern GSList *network_list;

#define FLAG_CYCLE				1
#define FLAG_USE_GLOBAL			2
#define FLAG_USE_SSL				4
#define FLAG_AUTO_CONNECT		8
#define FLAG_USE_PROXY			16
#define FLAG_ALLOW_INVALID		32
#define FLAG_FAVORITE			64
#define FLAG_COUNT				7

/* Login methods. Use server password by default - if we had a NickServ password, it'd be set to 2 already by servlist_load() */
#define LOGIN_DEFAULT_REAL		LOGIN_PASS		/* this is to set the default login method for unknown servers */
#define LOGIN_DEFAULT			0				/* this is for the login type dropdown, doesn't serve any other purpose */
#define LOGIN_MSG_NICKSERV		1
#define LOGIN_NICKSERV			2
#if 0
#define LOGIN_NS				3
#define LOGIN_MSG_NS			4
#define LOGIN_AUTH				5
#endif
#define LOGIN_SASL				6
#define LOGIN_PASS				7
#define LOGIN_CHALLENGEAUTH		8
#define LOGIN_CUSTOM			9

#define CHALLENGEAUTH_ALGO		"HMAC-SHA-256"
#define CHALLENGEAUTH_NICK		"Q@CServe.quakenet.org"

void servlist_init (void);
int servlist_save (void);
int servlist_cycle (server *serv);
void servlist_connect (session *sess, ircnet *net, gboolean join);
int servlist_connect_by_netname (session *sess, char *network, gboolean join);
int servlist_auto_connect (session *sess);
int servlist_have_auto (void);
int servlist_check_encoding (char *charset);
void servlist_cleanup (void);

ircnet *servlist_net_add (char *name, char *comment, int prepend);
void servlist_net_remove (ircnet *net);
ircnet *servlist_net_find (char *name, int *pos, int (*cmpfunc) (const char *, const char *));
ircnet *servlist_net_find_from_server (char *server_name);

void servlist_server_remove (ircnet *net, ircserver *serv);
ircserver *servlist_server_add (ircnet *net, char *name);
ircserver *servlist_server_find (ircnet *net, char *name, int *pos);

void joinlist_split (char *autojoin, GSList **channels, GSList **keys);
gboolean joinlist_is_in_list (server *serv, char *channel);
void joinlist_free (GSList *channels, GSList *keys);
gchar *joinlist_merge (GSList *channels, GSList *keys);

#endif
