try build

    environment:
      - TYPEORM_HOST=daily-postgres
      - PORT=5000
      - TZ=UTC
      - ACCESS_SECRET='topsecret'
      - DEFAULT_IMAGE_URL=https://res.cloudinary.com/daily-now/image/upload/s--P4t4XyoV--/f_auto/v1722860399/public/Placeholder%2001,https://res.cloudinary.com/daily-now/image/upload/s--VDukGCjf--/f_auto/v1722860399/public/Placeholder%2002,https://res.cloudinary.com/daily-now/image/upload/s--HRgLpUt6--/f_auto/v1722860399/public/Placeholder%2003,https://res.cloudinary.com/daily-now/image/upload/s--foaA6JGU--/f_auto/v1722860399/public/Placeholder%2004,https://res.cloudinary.com/daily-now/image/upload/s--CxzD6vbw--/f_auto/v1722860399/public/Placeholder%2005,https://res.cloudinary.com/daily-now/image/upload/s--ZrL_HSsR--/f_auto/v1722860399/public/Placeholder%2006,https://res.cloudinary.com/daily-now/image/upload/s--1KxV4ohY--/f_auto/v1722860400/public/Placeholder%2007,https://res.cloudinary.com/daily-now/image/upload/s--0_ODbtD2--/f_auto/v1722860399/public/Placeholder%2008,https://res.cloudinary.com/daily-now/image/upload/s--qPvKM23u--/f_auto/v1722860399/public/Placeholder%2009,https://res.cloudinary.com/daily-now/image/upload/s--OHB84bZF--/f_auto/v1722860399/public/Placeholder%2010,https://res.cloudinary.com/daily-now/image/upload/s--2-1xRawN--/f_auto/v1722860399/public/Placeholder%2011,https://res.cloudinary.com/daily-now/image/upload/s--58gMhC4P--/f_auto/v1722860399/public/Placeholder%2012
      - DEFAULT_IMAGE_RATIO=1
      - DEFAULT_IMAGE_PLACEHOLDER=data:image/jpeg;base64,/9j/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAKAAoDASIAAhEBAxEB/8QAFwAAAwEAAAAAAAAAAAAAAAAABAUGB//EACYQAAIABAQGAwAAAAAAAAAAAAECAAMEBRESE0IGByExQVFScZH/xAAVAQEBAAAAAAAAAAAAAAAAAAABA//EABURAQEAAAAAAAAAAAAAAAAAAAAR/9oADAMBAAIRAxEAPwCgPMKtsdvWjpamiGsuCBVZzn3NmOAB+wYUni23kkz71OM09XObd5jBKufNagklprk4jux9QBqP82/YpQ//2Q==
      - URL_PREFIX=http://localhost:4000
      - COMMENTS_PREFIX=http://localhost:5002
      - REDIS_HOST=daily-redis
      - REDIS_PORT=6379
      - COOKIES_KEY=topsecret
      - JWT_SECRET='|r+.2!!!.Qf_-|63*%.D'
      - JWT_AUDIENCE='Daily Staging'
      - JWT_ISSUER='Daily API Staging'
      - JWT_PUBLIC_KEY_PATH=/opt/app/.cert/public.pem
      - JWT_PRIVATE_KEY_PATH=/opt/app/.cert/key.pem
      - GROWTHBOOK_CLIENT_KEY='local'
      - MOCK_USER_ID=testuser

      with this 

      work with

NEXT_PUBLIC_API_URL=http://192.168.76.212:5000
NEXT_PUBLIC_SUBS_URL=ws://192.168.76.212:5000/graphql
NEXT_PUBLIC_DOMAIN=192.168.76.212
NEXT_PUBLIC_WEBAPP_URL=/
NEXT_PUBLIC_AUTH_URL=http://localhost
NEXT_PUBLIC_HEIMDALL_URL=http://localhost