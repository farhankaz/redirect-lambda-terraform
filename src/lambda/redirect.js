exports.handler = async (event) => ({
  statusCode: 302,
  headers: {
      Location: 'https://www.youracclaim.com/users/farhan-kazmi.fb2253a3/badges'
  }
});