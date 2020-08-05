declare module 'baretest' {
  export interface Test {
    (name: string, fn: () => Promise<void>): void;
    run(): Promise<boolean>;
    skip(fn: () => Promise<void>): void;
    // This isn't real, but skip ignores its args
    skip(name: string, fn: () => Promise<void>): void;
    // This isn't real, but skip ignores its args
    skip(name: string): void;
    before(fn: () => Promise<void>): void;
    after(fn: () => Promise<void>): void;
    only(name: string, fn: () => Promise<void>): void;
  }

  export default function (headline: string): Test;
}
