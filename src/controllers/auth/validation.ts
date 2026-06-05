export const isValidEmail = (email: string) => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

export const isValidPassword = (password: string) => {
  return /^(?=.*[A-Za-z])(?=.*\d).{8,}$/.test(password);
};