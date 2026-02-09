export function successResponse(data) {
  return {
    success: true,
    data
  };
}

export function errorResponse(message) {
  return {
    success: false,
    message
  };
}






