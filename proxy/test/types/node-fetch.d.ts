declare module 'node-fetch' {
  export default function(input: RequestInfo, init?: RequestInit): Promise<Response>;
}
